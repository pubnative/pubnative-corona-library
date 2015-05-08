![PNLogo](PNLogo.png)

PubNative is an API-based publisher platform dedicated to native advertising which does not require the integration of an SDK. Through PubNative, publishers can request over 20 parameters to enrich their ads and thereby create any number of combinations for unique and truly native ad units.

# pubnative-corona-library

pubnative-corona-library is a collection of Open Source tools to implement API based native ads in Corona SDK.

##Contents

* [Requirements](#requirements)
* [Install](#install)
* [Usage](#usage)
* [Misc](#misc)
    * [License](#misc_license)
    * [Contribution guidelines](#misc_contributing)

<a name="requirements"></a>
## Requirements

Corona libraries used by this library:
* [crypto](https://docs.coronalabs.com/api/library/crypto/index.html)
* [json](https://docs.coronalabs.com/api/library/json/index.html)
* [network](https://docs.coronalabs.com/api/library/network/index.html)

So, as described in the network library, you will need to add internet permissions to your Android `build.settings` file

```json
settings =
{
   android =
   {
      usesPermissions =
      {
         "android.permission.INTERNET",
      },
   },
}
```

<a name="install"></a>
## Install

* Download this repository
* Copy Pubnative folder into your application **project root folder** (other than the root folder won't work)

---

<a name="usage"></a>
## Usage

For the usage of the library all required methods are accessed through the `pubnative/main.lua` module, and in short, these are the basic steps to performa a request and start using the library

So in general, you will need to require the `pubnative/main.lua` module

```lua
local pubnative=require('pubnative.main')
```

###request.lua
######Methods
* **addParameters(key,value)**: Adds parameters to the request
* **print()**: Prints the currently configured request url
* **cancel()**: Cancels current request
* **start(listener)**: Starts a request with a given listener for callback

In order to create a request and get ads within your application, you will need to create and use a request, that in short steps would be:

* Create a request
* Add parameters to it
* Start the request with a listener
* Check in the listener for errors or ads

```lua
local function adsListener(event)
  if event.error then
    print(event.error)
  else
    -- Ads available in event.ads
  end
end

local function requestAds()
  local request = pubnative.createRequest()
  request.addParameter("app_token","<YOUR_APP_TOKEN>")
  request.addParameter("bundle_id", "<YOUR_BUNDLE_ID>")
  request.addParameter("icon_size", "100x100")
  request.addParameter("banner_size", "1200x627")
  request.addParameter("ad_count", 5)
  request.start(adsListener)
end
```

Any other parameter can be added as described in the [Client API Request](https://pubnative.atlassian.net/wiki/display/PUB/Client+API), the more parameters you describe, the more info will pubnative server have to serve an accurate ad to your public (increasing revenues).

###model.lua

Once the request is completed you will have a table of ads ready to be used.

######Fields

* **icon**: Name of the cached icon_url image in the `system.CachesDirectory`
* **banner**: Name of the cached banner_url image in the `system.CachesDirectory`
* **data**: Hash of fields from the json file as detailed in [Client API Response](https://pubnative.atlassian.net/wiki/display/PUB/Client+API#ClientAPI-4.1Native)

######Methods

* **open()**: Opens the ad in the device browser
* **confirmImpression()**: Confirms the impression of the ad within pubnative servers
* **print()**: Prints the title of the ad

For further details, please check the provided sample that requests 5 icons and shows them in the screen once a button is pushed.

---

<a name="misc"></a>
## Misc

<a name="misc_license"></a>
### License

This code is distributed under the terms and conditions of the MIT license.

<a name="misc_contributing"></a>
### Contributing

**NB!** If you fix a bug you discovered or have development ideas, feel free to make a pull request.
