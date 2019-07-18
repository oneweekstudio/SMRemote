<p align="center"><img src="screenshot/logo.png" width = "auto", height = "auto" ></p>

Bước 1: FIREBASE
=====

- Cấu hình trong firebase remote config
> Config key mặc định trong thằng FIREBASE:
````
  quangcao
  more_tool
  ad_dialog_loop
  ad_dialog_start
````
- Trong thằng quảng cáo mình cần chọn cấu hình JSON cho nó: Ví dụ cho Admob và Facebook test
>Admob
````
{
  "full": {
    "app_id": "ca-app-pub-3940256099942544~1458002511",
    "ads_id": "ca-app-pub-3940256099942544/4411468910",
    "format": "full",
    "status": "1",
    "network": "admob"
  },
  "reward": {
    "app_id": "",
    "ads_id": "",
    "format": "reward",
    "status": "0",
    "network": "admob"
  },
  "native": {
    "app_id": "",
    "ads_id": "",
    "format": "native",
    "status": "0",
    "network": "admob"
  },
  "banner": {
    "app_id": "ca-app-pub-3940256099942544~1458002511",
    "ads_id": "ca-app-pub-3940256099942544/2934735716",
    "format": "banner",
    "status": "1",
    "network": "admob"
  }
}
````
> Facebook
````
{
  "full": {
    "app_id": "1562525404054991",
    "ads_id": "1562525404054991_1698301837144013",
    "format": "full",
    "status": "1",
    "network": "facebook"
  },
  "reward": {
    "app_id": "",
    "ads_id": "",
    "format": "reward",
    "status": "0",
    "network": "facebook"
  },
  "native": {
    "app_id": "",
    "ads_id": "",
    "format": "native",
    "status": "0",
    "network": "facebook"
  },
  "banner": {
    "app_id": "1562525404054991",
    "ads_id": "1562525404054991_1698301767144020",
    "format": "banner",
    "status": "1",
    "network": "facebook"
  }
}
````
> Demo firebase config. Chúng ta có thể tạo một số thuộc tính khác cần thiết: ví dụ : banner_home
<p align="center"><img src="screenshot/step1.png" width = "auto", height = "auto" ></p>

Bước 2: PROJECT
=====
- Review về SMConfig chút: không dùng property default_loop và default_start cũng chẳng sao cả!
````
import Foundation
open class SMConfig : NSObject {

    @objc open var ad_dialog_start = 1
    @objc open var ad_dialog_loop = 1
    @objc open var more_tool = 1

    @objc open var default_start = 1
    @objc open var default_loop = 2

}
````
- Tạo 1 class kế thừa từ thằng SMConfig kia theo demo.
````
import Foundation
open class Dev : SMConfig {

    @objc var custom_property = 1
    @objc var banner_home = 1
}

````
Thế là bạn đã hoàn thành các bước config rồi.

Bước 3: Thần code trong 1 nốt nhạc
====
