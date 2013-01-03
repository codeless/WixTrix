WixTrix is a Shell script that grabs galleries from websites created with Wix.com


# Description

WixTrix will grab only those pictures inside defined galleries (photoStackerGallery).


# Usage

	./wixtrix.sh http://www.domain.com/

The grabbed pictures get stored to a folder named "www.domain.com". Each gallery inside the domain is stored in its own subfolder: www.domain.com/gallery1, www.domain.com/gallery2, asf.


# Requirements

- (wget)[http://gnu.org/s/wget]: File retriever through HTTP
- xpath: by Matt Sergeant
- (Image Magick)[http://www.imagemagick.org/]: for injecting IPTC information into images


# History

- Version 1.1.0, released on 2013-01-03
	- Downloaded pictures are arranged in gallery-subfolders
	- Added support for IPTC image data
- Version 1.0.0, released on 2013-01-02


# Ideas for improvements

- Create test-scenarios for the following cases:
  - Action to take on non-WIX.com sites


# Credits and Bugreports

WixTrix was written by Codeless (http://www.codeless.at/). All bugreports can be directed to more@codeless.at. Even better, bugreports are posted on the github-repository of this package: https://www.github.com/codeless/wixtrix.


# License

This work is licensed under a Creative Commons Attribution-ShareAlike 3.0 Unported License: http://creativecommons.org/licenses/by-sa/3.0/deed.en_US
