package body  Socket_Tools is
   use type Ada.Streams.Stream_Element_Offset;
   task body Driver_Thread is
      Last      : Ada.Streams.Stream_Element_Offset;
      From      : Sock_Addr_Type;
      Address   : Sock_Addr_Type;
   begin
      accept Start;
      if Parent.Socket_Mode = Socket_Stream then
         Accept_Socket (Parent.Socket.all, Parent.Local_Socket, Address);
      else
         Parent.Local_Socket := Parent.Socket.all;
      end if;

      Parent.Listner.On_Start;
      begin
         while Parent.Continue loop
            Receive_Socket (Parent.Local_Socket,
                            Item  => Parent.Buffer,
                            Last  => Last,
                            From  => From,
                            Flags => Parent.Flags.all);
            if Last >= Parent.Buffer'First then
               Parent.Listner.On_Data (Socket => Parent.Local_Socket,
                                       Item   => Parent.Buffer (Parent.Buffer'First .. Last),
                                       From   => From);
            end if;

         end loop;
      exception
         when E : GNAT.SOCKETS.SOCKET_ERROR =>
            if Parent.Continue then -- If not in shutdown state report error
               Parent.Listner.On_Exception (E);
            end if;
            Parent.Continue := False;
         when E : others =>
            Parent.Listner.On_Exception (E);
            Parent.Continue := False;
      end;
      Parent.Listner.On_Stop;
   end Driver_Thread;

   procedure Start (Self : in out  Socket_Listner_Driver) is
   begin
      if Self.Driver'Callable then
         Self.Driver.Start;
      else
         raise Program_Error with "Only possible to start driver once";
      end if;
   end;

   procedure Stop (Self : in out Socket_Listner_Driver) is
   begin
      Self.Continue := False;
      Shutdown_Socket (Self.Local_Socket);
      Close_Socket (Self.Local_Socket);
   exception
      when GNAT.SOCKETS.SOCKET_ERROR => null;
   end;
end Socket_Tools;
