# Uncomment this line to define a global platform for your project
 platform :ios, '9.0'

target 'NAIST Open Campus' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  #MQTT framework here
    #pod 'SwiftMQTT', :git => 'https://github.com/aciidb0mb3r/SwiftMQTT.git'
    #pod 'CocoaMQTT'
    pod 'Moscapsule', :git => 'https://github.com/flightonary/Moscapsule.git'
    pod 'OpenSSL-Universal', '~> 1.0.1.18'

  #googleMap Api here
  pod 'GoogleMaps'
  pod 'GooglePlaces' 

  # Pods for NAIST Open Campus

  target 'NAIST Open CampusTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'NAIST Open CampusUITests' do
    inherit! :search_paths
    # Pods for testing
  end

 # the source for using googleMap API
#source 'https://github.com/CocoaPods/Specs.git'
  #pod 'GoogleMaps'
  #pod 'GooglePlaces'


end
