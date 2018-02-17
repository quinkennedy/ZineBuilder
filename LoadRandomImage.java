import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.BufferedInputStream;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;

import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.swing.ImageIcon;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.plugins.jpeg.JPEGImageWriteParam;
import javax.imageio.stream.FileImageOutputStream;

import processing.core.*;

class LoadRandomImage {
  boolean greyScale = false;
  LoadRandomImage() {}
  
  private PImage getImage(String _url) {
    System.out.println("[LoadRandomImage.getImage] fetching " + _url);
    
    PImage myImage = new PImage();

    try {
      URL url = new URL(_url);
      URLConnection openConnection = url.openConnection();
      boolean check = true;

      try {
        openConnection.setRequestProperty("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.95 Safari/537.11");
        openConnection.connect();

        if (openConnection.getContentLength() > 8000000) {
          System.out.println(" file size is too big.");
          check = false;
        }
      } catch (Exception e) {
        System.out.println("Couldn't create a connection to the link, please recheck the link.");
        check = false;
        e.printStackTrace();
      }
      
      if (check) {
        BufferedImage _img = null;
        try {
          InputStream in = new BufferedInputStream(openConnection.getInputStream());
          ByteArrayOutputStream out = new ByteArrayOutputStream();
          byte[] buf = new byte[1024];
          int n = 0;
          while (-1 != (n = in.read(buf))) {
              out.write(buf, 0, n);
          }
          out.close();
          in.close();
          byte[] response = out.toByteArray();
          _img = ImageIO.read(new ByteArrayInputStream(response));
          PImage img = new PImage(_img.getWidth(),_img.getHeight(),PConstants.ARGB);
          _img.getRGB(0, 0, img.width, img.height, img.pixels, 0, img.width);
          img.updatePixels();
          myImage = img;
        } catch (Exception e) {
          System.out.println("couldn't read an image from this link.");
          e.printStackTrace();
        }
      }
    } catch( Exception e ) {
      System.out.println("if you're reading this it's too late");
    }

    return myImage;
  }
  
  PImage loadRandomImage(int _w, int _h) {
    return getImage("https://loremflickr.com/"+_w+"/"+_h+"/");
  }
  
  PImage loadRandomImage(int _w, int _h, String _k) {
    if( this.greyScale ) {
      return getImage("https://loremflickr.com/g/"+_w+"/"+_h+"/"+_k);
    } else {
      return getImage("https://loremflickr.com/"+_w+"/"+_h+"/"+_k);
    }
  }
  
  PImage loadRandomImage(int _w, int _h, String[] _ks) {
    if( this.greyScale ) {
      return getImage("https://loremflickr.com/g/"+_w+"/"+_h+"/"+String.join(",", _ks));
    } else {
      return getImage("https://loremflickr.com/"+_w+"/"+_h+"/"+String.join(",", _ks));
    }
  }
  
  PImage loadRandomImage(int _w, int _h, String[] _ks, String all) {
    if( this.greyScale ) {
      return getImage("https://loremflickr.com/g/"+_w+"/"+_h+"/"+String.join(",", _ks)+all);
    } else {
      return getImage("https://loremflickr.com/"+_w+"/"+_h+"/"+String.join(",", _ks)+all);
    }
  }
  
  PImage loadRandomImage(String url) {
    return getImage(url);
  }
  
  PImage loadRandomImage() {
    return getImage("https://loremflickr.com/320/240/");
  }
}