local pubnative=require('pubnative.main')
local widget=require('widget')

display.setStatusBar (display.HiddenStatusBar)


local function requestListener(event)
  if event.error then
    print(event.error)
  else

    for index,ad in pairs(event.ads) do
      display.newImage(ad.icon, system.CachesDirectory,(100*(index-1))+(10*(index-1)),display.contentHeight/2)
      ad.confirmImpression()
    end

  end
end

local function requestAds()

	local request = pubnative.createRequest()
  local app_token = "d26bba3bb7956ab4ed4f7db25393f154e30c13f5a1874e8fc08a21c919cce17b"

  if "Android"==system.getInfo("platformName") then
    app_token = "681427d73d03194d830e92667bb0429fb5a796322831b54573db2fd2081042bc"
  end

	request.addParameter("app_token", app_token)
	request.addParameter("bundle_id", "com.pubnative.pubnativeSample")
	request.addParameter("icon_size", "100x100")
	request.addParameter("banner_size", "1200x627")
  request.addParameter("ad_count", 5)

	request.start(requestListener)
end

local function handleButtonEvent( event )

    if ( "ended" == event.phase ) then
        requestAds()
    end
end

local button = widget.newButton
{
    left = 10,
    top = 0,
    width=display.contentWidth-20,
    height=display.contentHeight*0.15,
    id = "button1",
    label = "Request",
    onEvent = handleButtonEvent,
    cornerRadius = 6,
    fontSize=50,
    labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5 } },
    fillColor = { default={ 0.478, 0.129, 0.498, 1 }, over={ 0.478, 0.129, 0.498, 0.5 } },
    strokeWidth = 4,
    shape="roundedRect",
}
