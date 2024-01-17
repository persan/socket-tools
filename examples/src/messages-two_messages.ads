package Messages.Two_Messages is

   type Two_Message is new Messages.Root_Message with record
      Pos      : Position;
      End_Pos  : Position;
   end record;

   overriding function Constructor (S : not null access Ada.Streams.Root_Stream_Type'Class) return Two_Message;
   overriding function Get_Key (Self : Two_Message) return Key_Type;

end Messages.Two_Messages;
