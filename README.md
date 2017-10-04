# Fork notes:
This fork of TechWizTime's moonlight-retropie installation script updates the functionality to remove the mapping step. Most controller configs are built into moonlight-embedded at this point, and performing a 'map' caused the application to hang for me. I also fix the mapping and fps launch options to match the newest version of moonlight-embedded. Original README from TechWizTime below.

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

## Other Information
If you have a problem with this script, please let me know by submitting an Issue.

If you have want to improve this script, please do and you'll receive credit for this.

If you use this script in a YouTube video, please give my channel a shout out and maybe even leave a card to my channel. It doesn't hurt your viewers and we all watch each other anyway :)

If this script helped you out and you want to see more scripts like this (for other Raspberry Pi related things), then please subscribe to my YouTube channel or follow me on one of my Social Media platforms below.

| [YouTube](https://www.youtube.com/TechWizTime) | [Facebook](https://www.facebook.com/TechWizTime) | [Instagram](https://www.instagram.com/TechWizTime) | [Twitter](https://www.twitter.com/TechWizTime) |
| --- | --- | --- | --- |
