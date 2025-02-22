# VanguardGuard
Disable Vanguard from running on your machine at startup. Run an included script to allow it for the next boot only, then disable it again in the future.

This works by setting the two Windows services of Vanguard (vgc, vgk) to a 'disabled' start type on boot. This prevents them from running when the machine is started. When you run enableVanguard, it sets their boot type to 'auto' allowing them to start on the next boot. The setup script will set the disableVanguard script to run on boot AFTER the services have started. It will not stop them if they are already started, allowing one boot with Vanguard enabled, but preventing any further boots from accidentally leaving the services enabled.

# Setup
Simple to set up, just run setup.bat to add a task. Whenever you want to have Vanguard turned on, run the enableVanguard script, confirm it, and reboot your machine. This will allow Vanguard for exactly one boot.

