--==============================================================================
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--==============================================================================
local model={}

function model.new(adData)
  ------------------------------------------------------------------------------
  -- REQUIRES
  ------------------------------------------------------------------------------
  local core=require('pubnative.core')
  local json=require('json')
  ------------------------------------------------------------------------------
  -- FIELDS
  ------------------------------------------------------------------------------
  -- Public
  local self = {
    icon=nil,
    banner=nil,
    data=adData
  }
  -- Private
  local iconRequestID=nil
  local bannerRequestID=nil
  local listener=nil
  ------------------------------------------------------------------------------
  -- METHODS
  ------------------------------------------------------------------------------
  -- Private
  local function checkEnded(event)
    if self.icon and self.banner then
      listener(self)
    end
  end

  local function iconListener(event)
    if event.phase=="ended" then
      self.icon=event.response.filename
      checkEnded(event)
    end
  end

  local function bannerListener(event)

    if event.phase=="ended" then
      self.banner=event.response.filename
      checkEnded(event)
    end
  end

  local function confirmListener(event)
    if event.phase=="ended" then
      local confirmData=json.decode(event.response)
      if confirmData.status=="ok" then
        print("Impression confirmed: ", self.data.title)
      else
        print("Impression failed: ", self.data.title)
      end
    end
  end

  -- Public
  function self.loadResources(adLoadListener)
    listener=adLoadListener
    if self.data.icon_url then
      iconRequestID = network.download(self.data.icon_url,
                                       "GET",
                                       iconListener,
                                       {},
                                       core.md5String(self.data.icon_url),
                                       system.CachesDirectory)
    end

    if self.data.banner_url then
      bannerRequestID = network.download(self.data.banner_url,
                                         "GET",
                                         bannerListener,
                                         {},
                                         core.md5String(self.data.banner_url),
                                         system.CachesDirectory)
    end

  end

  function self.cancel()
    if iconRequestID then network.cancel(iconRequestID) end
    if bannerRequestID then network.cancel(bannerRequestID) end
  end

  function self.print()
    if self.data then print(tostring(self.data.title)) end
  end

  function self.open()
    system.openURL(self.data.click_url)
  end

  function self.confirmImpression()

    for i=1, #(self.data.beacons) do
      local beacon=self.data.beacons[i]
      if beacon.type=="impression" then
        network.request(beacon.url, "GET", confirmListener)
        break
      end
    end

  end
  ------------------------------------------------------------------------------
  if self.data then
    return self
  else
    return nil
  end
end

return model
