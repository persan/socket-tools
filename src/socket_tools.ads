with Ada.Exceptions;
with GNAT.Sockets;
with Ada.Streams;
package Socket_Tools is   
   use GNAT.Sockets;
   
   type Socket_Listner is limited interface;
   type Socket_Listner_Access is access all Socket_Listner'Class with Storage_Size => 0;
   
   procedure On_Start (Self   : Socket_Listner) is null;
   -- Called when the reader is activated and starts to read.
   
   procedure On_Data (Self   : Socket_Listner; 
                      Socket : Socket_Type;
                      Item   : Ada.Streams.Stream_Element_Array;
                      From   : Sock_Addr_Type) is abstract;
   -- Called when new data is read from tha socket.
   
   procedure On_Stop (Self   : Socket_Listner) is null;
   --  Last call before exit.
   
   procedure On_Exception (Self   : Socket_Listner; E : Ada.Exceptions.Exception_Occurrence) is null;
   --  Called when an exceptyion occurs.
   
   type Socket_Listner_Driver
     (Listner     : not null Socket_Listner_Access;
      Socket      : not null access constant Socket_Type;
      Socket_Mode : GNAT.Sockets.Mode_Type;
      Buffer_Size : Ada.Streams.Stream_Element_Offset;
      Flags       : access constant Request_Flag_Type) is tagged limited private;
   
   procedure Start (Self : in out Socket_Listner_Driver);
   -- To be called when the listening socket is ready to accepty data.
   
   procedure Stop (Self : in out Socket_Listner_Driver);
   
private
   
   task type Driver_Thread (Parent : not null access Socket_Listner_Driver) is 
      entry Start;      
   end Driver_Thread;
   
   type Socket_Listner_Driver (Listner     : not null Socket_Listner_Access;
                               Socket      : not null access constant Socket_Type;
                               Socket_Mode : GNAT.Sockets.Mode_Type;
                               Buffer_Size : Ada.Streams.Stream_Element_Offset;
                               Flags       : access constant Request_Flag_Type) is tagged limited record
      Buffer          : Ada.Streams.Stream_Element_Array (1 .. Buffer_Size);
      Driver          : Driver_Thread (Socket_Listner_Driver'Access);
      Local_Socket    : Socket_Type;
      Continue        : Boolean := True;

   end record;
end Socket_Tools;
