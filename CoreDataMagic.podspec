Pod::Spec.new do |s|
  version = "0.0.5"

  s.name         = "CoreDataMagic"
  s.version      = version
  s.summary      = "CoreDataMagic adds miscellaneous helpers to Core Data functionality."
  s.homepage     = "http://allogy.com/CoreDataMagic"

  s.license      = {
    :type => 'Allogy Interactive',
    :text => <<-LICENSE
              Copyright (c) 2012 Allogy Interactive. All rights reserved.
    LICENSE
  }

  s.author       = { "Richard Venable" => "richard@epicfox.com" }
  s.source       = { :git => "https://github.com/Allogy/CoreDataMagic.git", :tag => 'v' + s.version.to_s }
  s.platform     = :ios, '6.0'
  s.source_files = 'CoreDataMagic/**/*.{h,m}'
  s.framework  = 'Foundation', 'UIKit', 'CoreData'
  s.requires_arc = true

  s.dependency 'Omniscience'

end
