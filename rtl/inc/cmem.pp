{
    $Id: cmem.pp,v 1.14 2005/03/04 16:49:34 peter Exp $
    This file is part of the Free Pascal run time library.
    Copyright (c) 1999 by Michael Van Canneyt, member of the
    Free Pascal development team

    Implements a memory manager that uses the C memory management.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
unit cmem;

interface

Const
{$ifndef ver1_0}

{$if defined(win32)}
  LibName = 'msvcrt';
{$elseif defined(netware)}
  LibName = 'clib';
{$elseif defined(netwlibc)}
  LibName = 'libc';
{$elseif defined(macos)}
  LibName = 'StdCLib';
{$else}
  LibName = 'c';
{$endif}

{$else}

{$ifndef win32}
  {$ifdef netware}
  LibName = 'clib';
  {$else}
    {$ifdef netwlibc}
    LibName = 'libc';
    {$else}
      {$ifdef macos}
      LibName = 'StdCLib';
      {$else}
      LibName = 'c';
      {$endif macos}
    {$endif netwlibc}
  {$endif}
{$else}
  LibName = 'msvcrt';
{$endif}

{$endif}

Function Malloc (Size : ptrint) : Pointer; {$ifdef win32}stdcall{$else}cdecl{$endif}; external LibName name 'malloc';
Procedure Free (P : pointer); {$ifdef win32}stdcall{$else}cdecl{$endif}; external LibName name 'free';
function ReAlloc (P : Pointer; Size : ptrint) : pointer; {$ifdef win32}stdcall{$else}cdecl{$endif}; external LibName name 'realloc';
Function CAlloc (unitSize,UnitCount : ptrint) : pointer; {$ifdef win32}stdcall{$else}cdecl{$endif}; external LibName name 'calloc';

implementation

type
  pptrint = ^ptrint;

Function CGetMem  (Size : ptrint) : Pointer;

begin
  CGetMem:=Malloc(Size+sizeof(ptrint));
  if (CGetMem <> nil) then
    begin
      pptrint(CGetMem)^ := size;
      inc(CGetMem,sizeof(ptrint));
    end;
end;

Function CFreeMem (P : pointer) : ptrint;

begin
  if (p <> nil) then
    dec(p,sizeof(ptrint));
  Free(P);
  CFreeMem:=0;
end;

Function CFreeMemSize(p:pointer;Size:ptrint):ptrint;

begin
  if size<=0 then
    begin
      if size<0 then
        runerror(204);
      exit;
    end;
  if (p <> nil) then
    begin
      if (size <> pptrint(p-sizeof(ptrint))^) then
        runerror(204);
    end;
  CFreeMemSize:=CFreeMem(P);
end;

Function CAllocMem(Size : ptrint) : Pointer;

begin
  CAllocMem:=calloc(Size+sizeof(ptrint),1);
  if (CAllocMem <> nil) then
    begin
      pptrint(CAllocMem)^ := size;
      inc(CAllocMem,sizeof(ptrint));
    end;
end;

Function CReAllocMem (var p:pointer;Size:ptrint):Pointer;

begin
  if size=0 then
    begin
      if p<>nil then
        begin
          dec(p,sizeof(ptrint));
          free(p);
          p:=nil;
        end;
    end
  else
    begin
      inc(size,sizeof(ptrint));
      if p=nil then
        p:=malloc(Size)
      else
        begin
          dec(p,sizeof(ptrint));
          p:=realloc(p,size);
        end;
      if (p <> nil) then
        begin
          pptrint(p)^ := size-sizeof(ptrint);
          inc(p,sizeof(ptrint));
        end;
    end;
  CReAllocMem:=p;
end;

Function CMemSize (p:pointer): ptrint;

begin
  CMemSize:=pptrint(p-sizeof(ptrint))^;
end;

{$ifdef HASGETFPCHEAPSTATUS}  
function CGetHeapStatus:THeapStatus;

var res: THeapStatus;

begin
  fillchar(res,sizeof(res),0);
  CGetHeapStatus:=res;
end;

function CGetFPCHeapStatus:TFPCHeapStatus;

begin
  fillchar(CGetFPCHeapStatus,sizeof(CGetFPCHeapStatus),0);
end;
{$else HASGETFPCHEAPSTATUS}  
Procedure CGetHeapStatus(var status:THeapStatus);

begin
  fillchar(status,sizeof(status),0);
end;
{$endif HASGETFPCHEAPSTATUS}  


Const
 CMemoryManager : TMemoryManager =
    (
      NeedLock : false;
      GetMem : @CGetmem;
      FreeMem : @CFreeMem;
      FreememSize : @CFreememSize;
      AllocMem : @CAllocMem;
      ReallocMem : @CReAllocMem;
      MemSize : @CMemSize;
      GetHeapStatus : @CGetHeapStatus;
{$ifdef HASGETFPCHEAPSTATUS}  
      GetFPCHeapStatus: @CGetFPCHeapStatus;	
{$endif HASGETFPCHEAPSTATUS}  
    );

Var
  OldMemoryManager : TMemoryManager;

Initialization
  GetMemoryManager (OldMemoryManager);
  SetMemoryManager (CmemoryManager);

Finalization
  SetMemoryManager (OldMemoryManager);
end.

{
 $Log: cmem.pp,v $
 Revision 1.14  2005/03/04 16:49:34  peter
   * fix getheapstatus bootstrapping

 Revision 1.13  2005/02/28 15:38:38  marco
  * getFPCheapstatus  (no, FPC HEAP, not FP CHEAP!)

 Revision 1.12  2005/02/14 17:13:22  peter
   * truncate log

}
