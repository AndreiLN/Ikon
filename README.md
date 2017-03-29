#  :white_square_button:  Ikon  :black_square_button:
Identicon generator for Intersystems Caché. Good to use in Mojo applications.

## Parameters
1. Name that's will be converted;
2. Directory where the file will be generated;
3. Size of the image in pixels (Default = 250);
4. Amount of background red (Default = 255);
5. Amount of background green (Default = 255);
6. Amount of background blue (Default = 255).

## Example
```COS
Do ##class(Ikon.Identicon).%New("test","C:\Identicons\",250,255,255,155)
```
Result of example above:

![Result](https://github.com/AndreiLN/Ikon/blob/master/test.jpg)
