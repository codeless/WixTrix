#! /bin/bash

# WixTrix is a Shell script that grabs galleries
# from websites created with Wix.com
#
# Author: more@codeless.at
# Created on: 2013-01-02
#
# For a history asf. please see the accompanied
# README.md. The documentation inside this script
# is natural-docs friendly!


# Function: createDirectory
#
# Tries to create a directory, if it doesn't exist yet.
#
# Parameters:
#
# 	$1 - Name of directory to create
function createDirectory () {
	# If directory doesn't exist yet
	if [ ! -d $1 ]
	then
		# Attempt to create it
		/bin/mkdir $1
	fi
}

# Function: getXPath
#
# Queries the passed XPath.
#
# Parameters:
#
# 	$1 - XPath query
function getXPath () {
	# Filter stderr messages and wastebin them
	/usr/bin/xpath -q -e "$1" $localXMLFile 2>/dev/null
}


# Function: injectIPTCData
#
# Extracts the title- and the content-attribute of the currently
# processed image out of the main XML file. After the extraction
# process, the data is written to a text-file and gets injected
# as IPTC into the image using Image Magick.
#
# Parameters:
#
# 	$1 - Image filename
function injectIPTCData () {
	# Extract descriptive attributes like title- and content-tag
	imageTitle=`getXPath "string(($imagePath)/@title)"`
	imageContent=`getXPath "string(($imagePath)/@content)"`

	# Write IPTC data to a file
	iptcFile=$tmpDir/iptc.txt
	echo "8BIM#1028=\"IPTC\"" > $iptcFile
	echo "2#105#Headline=\"$imageTitle\"" >> $iptcFile
	echo "2#120#Caption=\"$imageContent\"" >> $iptcFile

	# Inject IPTC data
	/usr/bin/mogrify -profile $iptcFile $1
}


domain=$1

# Test for passed string (domain)
if [ ! "$domain" ]
then
	echo "Usage: ./wixtrix.sh http://www.domain.com/"
	exit
fi

# Create directory for domain
mainDir=`basename $domain`
createDirectory $mainDir

tmpDir="/tmp"

# Download HTML file, if not already there
indexFile=$tmpDir/index.$mainDir.html
if [ ! -s $indexFile ]
then
	/usr/bin/wget --quiet --output-document $indexFile $domain
fi

# Extract path to XML file
# Search for XML-filestring inside the HTML file
xmlParam=`/bin/cat $indexFile | /bin/grep --only-matching --perl-regex "%22[a-z0-9_]+\.xml"`
# Extract the XML filename
xmlFile=${xmlParam:3}
# Prepend path
localXMLFile="$tmpDir/$xmlFile"

# Download the XML file, if it doesn't exist already:
if [ ! -s $localXMLFile ]
then
	/usr/bin/wget --quiet --output-document=$localXMLFile \
		http://static.wix.com/doc/$xmlFile.z
fi

# Loop through galleries
galleryIndex=1
while [ true ]
do
	# Compile gallery filename
	galleryFile=$tmpDir/gallery.$galleryIndex.xml

	# Compile gallery path
	galleryPath="(//instance[@componentType='photoStackerGallery']/params/paramNode[@id='stackSlides'])[$galleryIndex]"

	# Save gallery into temporary XML file
	/usr/bin/xpath \
		-q -e "$galleryPath" \
		$localXMLFile  \
		> $galleryFile

	# If gallery
	if [ -s $galleryFile ]
	then
		echo ""
		echo "Grabbing gallery $galleryIndex"
		echo "***"

		# Compile name of gallery-directory
		galleryDir=$mainDir/gallery$galleryIndex

		# Create gallery directory
		createDirectory $galleryDir

		# Loop through images
		imageIndex=1
		while [ true ]
		do
			# Compile image file
			imageFile=$tmpDir/image.xml

			# Compile image path
			imagePath="(($galleryPath)/item/subitems/item[@sourceType='picture'])[$imageIndex]"

			# Extract image
			/usr/bin/xpath \
				-q -e "$imagePath" \
				$localXMLFile \
				> $imageFile

			# If image
			if [ -s $imageFile ]
			then
				echo "Grabbing image $imageIndex"

				# Extract image source
				imageSource=`getXPath "string(($imagePath)/@loadURL)"`

				# Compile path to image
				imageFile="$galleryDir/$imageSource"

				# Download gallery-image to gallery-directory,
				# when image doesn't exist already
				if [ ! -s $imageFile ]
				then
					/usr/bin/wget --quiet \
						--directory-prefix=$galleryDir \
						http://static.wix.com/media/$imageSource

					# Inject IPTC-information into downloaded image
					injectIPTCData $imageFile
				fi
			else
				break
			fi

			# Raise index for next image
			imageIndex=$(($imageIndex+1))
		done
	else # No gallery anymore
		# Remove empty gallery file
		/bin/rm $galleryFile
		break
	fi

	# Raise index for next gallery
	galleryIndex=$(($galleryIndex+1))
done
