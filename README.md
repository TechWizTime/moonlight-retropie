# moonlight.sh

## What is new

- Now you don't need to be root to run this script (still need to provide your password!)
- Refactored the code, now it's a little bit easier to maintain since it's function based
- The script can be run from anywhere in the system now, not only $HOME!
- Now you can choose your sound device (HDMI or Audio Jack) 
- Created 3 new menu entries: 1 - This very own script, 2 - Change sound out to HDMI and 3 -Change sound out to audio jack
- Created a (crude) command line interface. Now you can pass a number as an argument for this script
- Now there's some what of a error handling, so if something happens along the way you'll actually see it
- It'll use the debian strech repo, so no more libssl1.0 errors when installing (need to test this in a new system)
- 

# To-Do
- Controller mapping (it's not a priority, since most controllers work out-of-the-box)


# --------- ORIGINAL TECHWIZTIME README ---------

# moonlight-retropie
The Install &amp; Setup Script for Moonlight within RetroPie 4.2+ from **TechWizTime**

This script will install the Steam Streaming application Moonlight on your Raspberry Pi. I highly recommend using the latest version of RetroPie (currently at 4.3).

## What does this do
This script currently will do the following:
- Install Moonlight
- Create Launch Scripts for 720p 30fps, 720p 60ps, 1080p 30fps, 1080p 60fps
- Pair With GameStream on PC
- Setup a Steam Menu in RetroPie

## How to use this
In RetroPie, go to the Command Line and type the following to download the script:
```
wget https://raw.githubusercontent.com/TechWizTime/moonlight-retropie/master/moonlight.sh
```
```
sudo chmod +x moonlight.sh
```
Then run the script:
```
sudo ./moonlight.sh
```

## If you get a TLS or SSL Error
Sometimes, this can happen when trying to wget the script above. If it does, try this wget command instead
```
wget https://raw.githubusercontent.com/TechWizTime/moonlight-retropie/master/moonlight.sh  --no-check
```

And if you are feeling particulary lazy, here's a shortlink via my website
```
wget https://techwiztime.com/moonlight.sh  --no-check
```
## Acknowledgements
@etgrieco - Thanks for fixing the script when the mapping broke!


## Other Information
If you have a problem with this script, please let me know by submitting an Issue.

If you have want to improve this script, please do and you'll receive credit for this.

If you use this script in a YouTube video, please give my channel a shout out and maybe even leave a card to my channel. It doesn't hurt your viewers and we all watch each other anyway :)

If this script helped you out and you want to see more scripts like this (for other Raspberry Pi related things), then please subscribe to my YouTube channel or follow me on one of my Social Media platforms below.

| [YouTube](https://www.youtube.com/TechWizTime) | [Facebook](https://www.facebook.com/TechWizTime) | [Instagram](https://www.instagram.com/TechWizTime) | [Twitter](https://www.twitter.com/TechWizTime) |
| --- | --- | --- | --- |
