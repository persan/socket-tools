with Ada.Exceptions;
with Ada.Streams;
with Ada.Text_IO; use Ada.Text_IO;
with GNAT.Sockets;
with GNAT.Source_Info;
with GNAT.Formatted_String;
with Socket_Tools;
procedure Main is
   package Listners is
      type Pasive_Listner is new Socket_Tools.Socket_Listner with null record;
      overriding procedure On_Start (Self   : Pasive_Listner);
      overriding procedure On_Data (Self   : Pasive_Listner;
                                    Socket : GNAT.Sockets.Socket_Type;
                                    Item   : Ada.Streams.Stream_Element_Array;
                                    From   : GNAT.Sockets.Sock_Addr_Type);
      overriding procedure On_Stop (Self   : Pasive_Listner);
      overriding procedure On_Exception (Self   : Pasive_Listner; E : Ada.Exceptions.Exception_Occurrence);

      task type Active_Listner is new Socket_Tools.Socket_Listner with
         entry On_Start;
         entry On_Data (Socket : GNAT.Sockets.Socket_Type;
                        Item   : Ada.Streams.Stream_Element_Array;
                        From   : GNAT.Sockets.Sock_Addr_Type);
         entry On_Exception (E : Ada.Exceptions.Exception_Occurrence);
         entry On_Stop;
      end Active_Listner;
   end;

   package body Listners is
      overriding procedure On_Start (Self   : Pasive_Listner) is
      begin
         Put_Line (GNAT.Source_Info.Enclosing_Entity);
      end;
      overriding procedure On_Data (Self   : Pasive_Listner;
                                    Socket : GNAT.Sockets.Socket_Type;
                                    Item   : Ada.Streams.Stream_Element_Array;
                                    From   : GNAT.Sockets.Sock_Addr_Type) is
      begin
         Put_Line (GNAT.Source_Info.Enclosing_Entity &
                     "( Socket =>" & Socket'Image &
                     ", Item => " & Item'Image &
                     ", From => " & From'Image);
      end;
      overriding procedure On_Stop (Self   : Pasive_Listner) is
      begin
         Put_Line (GNAT.Source_Info.Enclosing_Entity);
      end;

      overriding procedure On_Exception (Self   : Pasive_Listner; E : Ada.Exceptions.Exception_Occurrence) is
      begin
         Put_Line (GNAT.Source_Info.Enclosing_Entity);
         Put_Line (E.Exception_Information);
      end;

      task body Active_Listner is
      begin
         Read_Loop : loop
            select
               accept On_Start do
                  Put_Line (GNAT.Source_Info.Enclosing_Entity);
               end On_Start;

            or
               accept On_Data (Socket : GNAT.Sockets.Socket_Type;
                               Item   : Ada.Streams.Stream_Element_Array;
                               From   : GNAT.Sockets.Sock_Addr_Type)  do
                  Put_Line (GNAT.Source_Info.Enclosing_Entity &
                              "( Socket =>" & Socket'Image &
                              ", Item => " & Item'Image &
                              ", From => " & From.Addr.Sin_V4'Image);
               end On_Data;
            or
               accept On_Stop
               do
                  Put_Line (GNAT.Source_Info.Enclosing_Entity);
               end On_Stop;
               exit Read_Loop;

            or
               accept On_Exception (E : Ada.Exceptions.Exception_Occurrence) do
                  Put_Line (GNAT.Source_Info.Enclosing_Entity);
                  Put_Line (E.Exception_Information);
               end On_Exception;
            or
               delay 1.0;
               Put_Line (GNAT.Source_Info.Enclosing_Entity);
            end select;
         end loop Read_Loop;
      end Active_Listner;
   end;

   use GNAT.Formatted_String;
   use type Ada.Streams.Stream_Element_Offset;
   Server : aliased GNAT.Sockets.Socket_Type;

   --  Listner  : aliased Listners.Pasive_Listner;
   Listner : aliased Listners.Active_Listner;

   Data   : aliased String (1 .. 3);
   Buffer : Ada.Streams.Stream_Element_Array (1 .. Data'Size / Ada.Streams.Stream_Element'Size) with
     Import => True,
     Address => Data'Address;

   Driver        : Socket_Tools.Socket_Listner_Driver
     (Listner     => Listner'Unchecked_Access,
      --  Unchecked_Access since we are passing the referece to  an outer scope.

      Socket      => Server'Unchecked_Access,
      --  Unchecked_Access since we are passing the referece to  an outer scope.
      Socket_Mode => GNAT.Sockets.Socket_Datagram,

      Buffer_Size => (Buffer'Size / Ada.Streams.Stream_Element'Size),
      --  Same sice on reciev buffer as on data sent,

      Flags       => GNAT.Sockets.No_Request_Flag'Unrestricted_Access
      --  Unrestricted_Access since is'nt aliased
     );

   Address       : GNAT.Sockets.Sock_Addr_Type;

   Provider        : GNAT.Sockets.Socket_Type;
   Last            : Ada.Streams.Stream_Element_Offset;
   use GNAT.Sockets;
begin

   Address.Addr := Addresses (Get_Host_By_Name (Host_Name), 1);
   Address.Port := 5876;

   Server.Create_Socket (Mode => Driver.Socket_Mode);
   Server.Set_Socket_Option (Socket_Level, (Reuse_Address, True));
   Server.Set_Socket_Option (IP_Protocol_For_IP_Level, (Multicast_Loop, True));

   Server.Bind_Socket (Address);

   Driver.Start;

   Provider.Create_Socket (Mode => Driver.Socket_Mode);
   Provider.Set_Socket_Option (IP_Protocol_For_IP_Level, (Multicast_Loop, True));
   Provider.Connect_Socket (Address);

   for I in 1 .. 5 loop
      Data := -(+("%03d") & I);
      Provider.Send_Socket (Buffer, Last, Address);
      delay 0.2;
   end loop;

   Driver.Stop;
   delay 1.0;

end Main;
