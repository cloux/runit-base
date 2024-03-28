<a href="https://devuan.org/os/init-freedom/"><img src="https://devuan.org/ui/img/if.png" width="110" height="150" align="right"></a>
# Runit base

## About

This is a collection of runit-init scripts and config files required for runit when used as the default init system, PID1 process and service supervisor. This repository should work with any runit installation, but was developed specifically for [aws-devuan](https://github.com/cloux/aws-devuan) in combination with other tools provided by [Simple Installer](https://github.com/cloux/sin).

---
## Features

 * collection of daemontools-compatible [runscripts](etc/sv)
 * runit stage [control scripts](etc/runit)
 * clean OS symlinks required by runit
 * networking, cron and other scripts that include runit support

---
## Installation

Installation method depends on your use case. The preferred and tested method to install runit as the default init system is using the [Simple Installer](https://github.com/cloux/sin) and run:

```
sin runit-init
```

You can also use scripts from this repository separately. For example to download and use runscripts only:

```
git clone https://github.com/cloux/runit-base
cp -ufvRP -t /etc/sv/ runit-base/etc/sv/
```

---
<a href="http://www.wtfpl.net"><img src="http://www.wtfpl.net/wp-content/uploads/2012/12/wtfpl-badge-2.png" align="right"></a>
## License

This work is free. You can redistribute it and/or modify it under the terms of the Do What The Fuck You Want To Public License, Version 2, as published by Sam Hocevar. See http://www.wtfpl.net for more details. If you feel that releasing this work under WTFPL is not appropriate, since some of the code might be derivative and thus possibly breaking some other license... just do WTF you want to.

---
## Author

This repository is maintained by _jan@wespe.dev_

### Disclaimer

I do not have any personal feelings towards any init, nor any other software or its developers. As a sysadmin I could not care less which init system is in use, as long as it works. Also, I do not claim fitness of this project for any particular purpose and do not take any responsibility for its use. You should always choose your system and all of its components very carefully, if something breaks it's on you. See [license](#license).

_NOTE:_ Much of the Runit base structure is "borrowed" from the [void-runit](https://github.com/voidlinux/void-runit) and modified to allow initramfs-free operation and additional service support including X11 sessions.

### Contributing

I will keep this project alive as long as I can, and as long as there is some interest. This is however a private project, so my support is fairly limited. Any help with further development, testing, and bugfixing will be appreciated. If you want to report a bug, please either [raise an issue](https://github.com/cloux/runit-base/issues), or fork the project and send me a pull request.

### Thanks to

 * Devuan Project: https://devuan.org
 * Void Linux: https://www.voidlinux.org
 * Runit and Socklog author Gerrit Pape: https://smarden.org/pape
 * Flussence: https://gitlab.com/flussence/runit-scripts

---