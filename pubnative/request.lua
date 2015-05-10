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
local request={}

function request.new()
  ------------------------------------------------------------------------------
  -- REQUIRES
  ------------------------------------------------------------------------------
  local core=require('pubnative.core')
  local model=require('pubnative.model')
  local network=require('network')
  local json=require('json')

  ------------------------------------------------------------------------------
  -- FIELDS
  ------------------------------------------------------------------------------
  -- Public
  local self = {}
  -- Private
  local baseURL="http://api.pubnative.net/api/partner/v2/promotions/"
  local nativeAPI="native"
  local parameters={}
  local requestID=nil
  local listener=nil
  local ads={}
  local adCount=0
  ------------------------------------------------------------------------------
  -- METHODS
  ------------------------------------------------------------------------------

  -- Private
  local function setDefaults()

    if not parameters.os then
      if not "simulator"==system.getInfo("environment") then
        parameters.os=system.getInfo("platformName")
      else
        parameters.os="ios"
        if core.isAndroid() then
          parameters.os="android" --Trick to make it work in the simulator
        end
      end
    end

    if not parameters.os_version then
      parameters.os_version=system.getInfo("platformVersion")
    end

    if not parameters.locale then
      parameters.locale=system.getPreference("locale","language")
    end

    if not parameters.device_model then
      parameters.device_model=system.getInfo("model")
    end

    if core.isIOS() then
      if not parameters.apple_idfa then
        parameters.apple_idfa=system.getInfo("iosAdvertisingIdentifier")
      end
    elseif core.isAndroid() then
      if not parameters.bundle_id then
        parameters.bundle_id=system.getInfo("androidAppPackageName")
      end
    end

    if not parameters.apple_idfa and
       not parameters.android_advertiser_id then
      parameters.no_user_id=1
    end

  end

  local function isValid()
    isValid=false
    if parameters.app_token and
       parameters.bundle_id and
       parameters.os and
       parameters.os_version and
       parameters.device_model and
       parameters.icon_size and
       parameters.banner_size and
       (parameters.apple_idfa or
        parameters.android_advertiser_id or
        parameters.no_user_id) then
      isValid=true
    end
    return isValid
  end

  local function urlEncode(url)
    if (url) then
      url = string.gsub (url, "\n", "\r\n")
      url = string.gsub (url, "([^%w ])", function (c) return string.format ("%%%02X", string.byte(c)) end)
      url = string.gsub (url, " ", "+")
    end
    return url
end

  local function url()
    local url=nil
    setDefaults()
    if isValid() then
      url=string.format("%s%s?",baseURL,nativeAPI)
      local firstParameter=false
      for key,value in pairs( parameters ) do

        local parameterFormat="%s=%s"
        if value and string.match(tostring(value), ",") then
          parameterFormat="%s=%q"
        end
        local encodedValue=urlEncode(value)
        local parameterString=string.format(parameterFormat,
                                            tostring(key),
                                            tostring(encodedValue))
        local globalFormat="%s&%s"
        if firstParameter then
          globalFormat="%s%s"
          firstParameter=false
        end
        url=string.format(globalFormat, url, parameterString)
      end
    end
    return url
  end

  local function createError(message)
    local errorMessage=nil
    if message then
      errorMessage="Pubnative - Error: "..message
    end
    return errorMessage
  end

  local function invokeEnded(data, error)

    if listener then
      listener({ads=data, error=createError(error)})
    else
      print("Pubnative - request '"..tostring(requestID).."' ended without listener")
    end

  end

  local function adListener(ad)
    if ad then table.insert(ads, ad) end
    adCount=adCount-1
    if adCount==0 then
      invokeEnded(ads)
    end
  end

  local function printNetworkEvent(event)

    print("event.response - "..tostring(event.response))
    for key, value in pairs(event.responseHeaders) do
      print("HEADER - "..tostring(key).." : "..tostring(value))
    end
    print("event.isError - "..tostring(event.isError))
    print("event.name - "..tostring(event.name))
    print("event.url - "..tostring(event.url))
    print("event.phase - "..tostring(event.phase))
    print("event.status - "..tostring(event.status))
    print("event.responseType - "..tostring(event.responseType))

  end

  local function networkListener(event)

    --Uncomment for debug only
    --printNetworkEvent(event)

    if not event.isError then

      local isPhaseOK       = event.phase=="ended"
      local isStatusOK      = event.status==200

      if isPhaseOK and isStatusOK then

        local isResponseOK    = event.responseType=="text"
        local contentType = event.responseHeaders["Content-Type"]
        local isContentTypeOK = string.match(contentType, "application/json")~=nil

        if isResponseOK and isContentTypeOK then
          local data=json.decode(event.response)
          local isDataStatusOK=(data.status=="success" or data.status=="ok")

          if data and isDataStatusOK then
            adCount=#(data.ads)
            for i=1, adCount do
              model.new(data.ads[i]).loadResources(adListener)
            end

          else
            invokeEnded(nil,"parse error")
          end
        else
          invokeEnded(nil,"server error")
        end
      end
    end
  end

  -- Public
  function self.addParameter(parameter,value)
    parameters[parameter]=value
  end

  function self.start(requestListener)
    listener=requestListener
    if listener then
      local urlString=url()
      if urlString then
        requestID = network.request(urlString,"GET",networkListener)
      else
        invokeEnded(nil,"invalid data for request")
      end
    end
  end

  function self.cancel()
    if requestID then
      network.cancel(requestID)
    end
  end

  function self.print()
    local urlString=url()
    if urlString then
      print(urlString)
    else
      print("Pubnative - The current request is not valid")
    end

  end
  ------------------------------------------------------------------------------
  return self
end

return request
