package body Messages.Two_Messages is

   MSG_KEY : constant := 33;

   overriding function Constructor (S : not null access Ada.Streams.Root_Stream_Type'Class) return Two_Message is
   begin
      return Ret : Two_Message do
         Two_Message'Read (S, Ret);
      end return;
   end;
   overriding function Get_Key (Self : Two_Message) return Key_Type is (MSG_KEY);
begin
   Register (MSG_KEY, Two_Message'Tag);
end Messages.Two_Messages;
