Pod::Spec.new do |s|

  s.name                  = "MapScaleBar"
  s.version               = "1.0.0"
  s.license               = 'MIT'
  s.summary               = "A bar scale for ´MKMapView´"
  s.homepage              = 'https://github.com/ReneLindhorst/MapScaleBar'
  s.authors               = { 
                              'Rene Lindhorst' => 'rene.lindhorst@lindhorst.it'
                            }
  s.ios.deployment_target = '8.0'
  s.source                = { :git => 'https://github.com/ReneLindhorst/MapScaleBar.git', :tag => s.version }
  s.source_files          = 'Source/*.swift'
  
end
