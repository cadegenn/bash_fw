# bash_fw

Simple bash framework to ease writing and debugging scripts

## How to use

  * Download latest release into your scripts repository.
  * Use the `skel.sh` as a template for your own scripts :

```console
cp -a skel.sh myscript.sh
```

Start scripting between the lines
```shell
#################################################
##
## YOUR SCRIPT GOES HERE !
##
##################################################



##################################################
##
## YOUR SCRIPT END HERE !
##
##################################################
```

Now in your code, you can simply use following syntax :

```shell
einfo "Some informations"
edebug "MYVAR = ${MYVAR}"
eexec cp -a afile.txt /to/another/place/
```

## Get the complete documentation

You can generate the doc with Doxygen. Simply do the following
  * install doxygen for your distribution
  * execute this
```shell
cd doc
doxygen Doxyfile
```

