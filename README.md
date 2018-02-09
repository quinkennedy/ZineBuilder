# ZineBuilder

This is a Processing sketch that builds a zine from a series of XML files.

Upon launching the app, you can select a directory to load the zine from.
At the least this directory should contain a `zine.xml` file.
It will also look for `settings.xml` and `style.xml`.

Using the UI, you can set the various settings for the zine.
Don't forget to go to the _Details_ tab.
When you generate your zine, the current settings will be saved over `settings.xml`.

`style.xml` can be used to set various font sizes used for different parts of the zine.

# Format for the zine.xml file

The zine.xml file (right now the file must use that name) uses a ```<zine>``` tag to create a new zine. Typically this is followed by a ```<cover>``` tag which have some special properties vs. the typical ```<spread>``` tag used to define a new set of two pages. Each spread has an id element that will tell the Zine Generator what order to render the spreads. Typically these are in order to maintain the sanity of the people collaborating.
    
## Covers and Spreads

Cover and spreads are composed of two ```<page>``` tags to represent the two pages of the spread or cover. Pages can include content using a few different tags

```
<heading></heading>
<subheading></subheading>
<image src="image.png"></image>
<footer></footer>
```

## Tag System

````
(<var key="num"></var>/150)
````

## Example zine.xml file

```
<?xml version="1.0"?>
<zine>
<cover id="1">
    <page id="2">
        <heading>Heading Goes Here</heading>
    </page>
    <page id="1">
        <image src="images/jj2.png"></image>
        <heading>Generative Zine Workshop</heading>
        <subheading>A generative zine from a group of people.</subheading>
        <footer>Issue 001: Strange Meetup (<var key="num"></var>/150)</footer>
    </page>
</cover>
  <spread id="5">
    <page id="8"> 
     <heading>My Zine Pages</heading>
       <subheading></subheading>
       <body></body>
       <footer></footer>
       <image src="images/drawing2b.jpg"></image>
    </page>
    <page id="9">
        <heading>Nothing is Static</heading>
        <subheading></subheading>
        <body></body>
 <footer></footer>
<image src="images/felixhess2.jpg"></image>
    </page>
</spread>
</zine>
</xml>
```

