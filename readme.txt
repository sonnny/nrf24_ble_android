

notes:

  demo of using android app bluetooth to picow then
    using nrf24l01 attached to picow to another pico nrf24l01 receiver
    serves as a bridge remote from android app to long distance nrf24l01
    can be use for remote control boat, cars, planes
    
  nrf24l01 routines are from github.com/guser210


android app notes:
  make sure to give this app location permission under app settings
  some android device ask for permission, some don't
  make sure bluetooth is on

  make sure to add bluetooth permission to filename:
    android/app/src/main/AndroidManifest.xml

<uses-permission android:name="android.permission.BLUETOOTH_SCAN"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>


nrf24l01 receive notes:


nrf24l01 transmit/ble notes:
