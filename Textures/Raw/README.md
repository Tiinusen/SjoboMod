# Textures (Raw)
This folder contains all gimp files and exported dds files.

## Getting started
I used Gimp since I can't afford a Photoshop license at the moment, but yeah it does the trick.

### Modify an existing texture
To do this I recommend opening the **Texture browser** in **POSTed** 
and look for a similar texture or weapon/model of what you are doing.

Press the Export button and export it into the **Raw** folder.

Open the texture in Gimp and save it as a xcf file with a name you might find suitable.

Keep in mind that the name needs to be original over the whole Postal 2 game (according to modders).

### Export
If you have more than one layer, then merge those layers (but not the mipmap layers if you have those loaded into Gimp),
the reason is that you can only export one layer with "**.dds**" and the exporter will then generate it's own layers for Mipmaps.

Press the Export button in Gimp and choice the extension "**.dds**".

Compression to be used should be "**BC3 / DXT5**" or else POSTed can't import it.

**Generate Mipmaps** or else you will get a shimmering effect that's unwanted in-game on a distance.

Then export it into the **Raw** folder.

### Import into POSTed
Start **POSTed** (duh) and go into **Texture Browser**, Press **Import** button.

* **Package:** _Name of package, anything unique but not mod name, in our case here "**SjoboModTex**"_
* **Group:** _Name of category, helps keeping textures together (ex. "**Walls**" or "**Clipboard**")_
* **Name:** _Name of texture, needs to be unique over all over Postal_

_Keep in mind that spaces are not allowed in any of the fields, use underscore to separate or camelcase_

Repeat until you have imported all Textures you want into your package.

Save package into **Textures** folder with the same as entered on Package field above, use "**.utx**" as extension.