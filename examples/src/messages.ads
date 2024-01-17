with Ada.Streams;
private with Ada.Tags;
package Messages is

   type Root_Message is abstract tagged record
      null;
   end record with
     Input'Class => Input,
       Output'Class => Output;

   --  Define all types that is used to build a message here.
   type Position is record
      X, Y, Z : Float := 0.0; -- Ranges from 0.0 to 256.0
   end record with
     Read => Read,
     Write => Write;
   procedure Read (S : not null access Ada.Streams.Root_Stream_Type'Class; Item : out Position);
   procedure Write (S : not null access Ada.Streams.Root_Stream_Type'Class; Item : in Position);
   type Key_Type is new Ada.Streams.Stream_Element;

   function Input (S : not null access Ada.Streams.Root_Stream_Type'Class) return Root_Message'Class;

   procedure Output (S : not null access Ada.Streams.Root_Stream_Type'Class; Item : Root_Message'Class);
   function Constructor (Params : not null access Ada.Streams.Root_Stream_Type'Class) return Root_Message is abstract;
   function Get_Key (Self : Root_Message) return Key_Type is abstract;

private
   procedure Register (Key : Messages.Key_Type; Tag : Ada.Tags.Tag);
end Messages;
