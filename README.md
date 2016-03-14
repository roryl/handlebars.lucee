# Handlebars.lucee
An implementation of the Handlebars.js templating language in Lucee

###Requirements
* Built for and tested with Lucee 4.5+
* Requires the presence of rhino-1.7R4.jar on the *Servlet Container class path* Because of the way the underlying Handlebars.java class instantiates Rhino, Lucee cannot dynamically load this jar, and it cannot be in the Railo Server or Web Contexts.

###Installation
The first time you instantiate the Handlebars.cfc, it will try to install the Rhino jar files and will throw an error prompting you to restart your Lucee instance to continue.

```coldfusion
//With throw installed and needs restart, or was failed
Handlebars = new Handlebars();
```

To troubleshoot issues with the installation, do not call the constructor, and then the install methods can be tried:

```coldfusion
Handlebars = createObject("handlebars");
writeDump(Handlebars.isInstalled()); //returns true or false if it can fine Rhino
Handlebars.install(); //attemptes the installation
```
