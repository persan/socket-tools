package Messages.One_Messages is

   type One_Message is new Messages.Root_Message with record
      Pos  : Position;
      Name : String (1 .. 2);
   end record;   
   
   overriding function Constructor (S : not null access Ada.Streams.Root_Stream_Type'Class) return One_Message;
   overriding function Get_Key (Self : One_Message) return Key_Type;

end Messages.One_Messages;
