package body Messages.One_Messages is

   MSG_KEY : constant := 1;
   overriding function Constructor (S : not null access Ada.Streams.Root_Stream_Type'Class) return One_Message is
   begin
      return Ret : One_Message do
         One_Message'Read (S, Ret);
      end return;
   end;
   overriding function Get_Key (Self : One_Message) return Key_Type is (MSG_KEY);
begin
   Register (MSG_KEY, One_Message'Tag);
end Messages.One_Messages;
