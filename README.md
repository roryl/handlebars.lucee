# Handlebars.lucee
An implementation of the Handlebars.js templating language in Lucee

###Requirements
* Built for and tested with Lucee 4.5+
* Requires the presence of rhino-1.7R4.jar on the Servlet Container class path

###Installation
The first time you instantiate the Handlebars.cfc, it will try to install the Rhino jar files and will throw an error prompting you to restart your Lucee instance.

```coldfusion
Handlebars = new Handlebars();
```
