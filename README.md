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

### Special variable types

### Boolean variables

To set a variable to `true`, simply assign a value to it. For example, all these statement are equivalent and will be trated as `true` :
```shell
var1="true"
var1="false"
var1="something"
var1=0
```

To set a variable to `false`, simply unassign the variable like this
```shell
var1=
```

TODO: write a `isBool()` function to abstract this. This way we could handle that `var1="false"` is really process as `false`. We could also negate special words like "no", "disabled", or even 0.

## Get the complete documentation

You can generate the doc with Doxygen. Simply do the following
  * install doxygen for your distribution
  * execute this
```shell
cd doc
doxygen Doxyfile
```

