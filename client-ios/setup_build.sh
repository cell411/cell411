
#
# Check if Homebrew is installed
#
which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
	echo "Installing Homebrew"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
	echo "Homebrew already installed"
fi

#

# TODO: move to a build file
# Stolen from https://developer.apple.com/library/archive/technotes/tn2339/_index.html
#To list all schemes in your workspace, run the following command in Terminal:
xcodebuild -list -workspace cell411.xcworkspace

#To list all targets, build configurations, and schemes used in your project, run the following command in Terminal:
#`xcodebuild -list -project <your_project_name>.xcodeproj`

#To build a scheme in your project, run the following command in Terminal:
 
#`xcodebuild -scheme <your_scheme_name> build`

#### hmmm
sudo gem install cocoapods

pod install

#after a time you will need to run 
#pod update
