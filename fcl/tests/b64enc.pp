// $Id: b64enc.pp,v 1.4 2005/02/14 17:13:18 peter Exp $

// base64-encodes data from StdIn and writes the output to StdOut
// (c) 1999 Sebastian Guenther

{$MODE objfpc}

program b64enc;
uses classes, base64, sysutils;
var
  b64encoder: TBase64EncodingStream;
  InputStream, OutputStream: TStream;
  IsEnd: Boolean;
begin

  InputStream := THandleStream.Create(StdInputHandle);
  OutputStream := THandleStream.Create(StdOutputHandle);

  b64encoder := TBase64EncodingStream.Create(OutputStream);

  while not IsEnd do
    try
      b64encoder.WriteByte(InputStream.ReadByte);
    except
      on e: EStreamError do IsEnd := True;
    end;

  b64encoder.Free;
  InputStream.Free;
  OutputStream.Free;
end.


{
  $Log: b64enc.pp,v $
  Revision 1.4  2005/02/14 17:13:18  peter
    * truncate log

}
