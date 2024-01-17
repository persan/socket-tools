with Ada.Containers.Hashed_Maps;
with Ada.Unchecked_Conversion;
with Ada.Tags.Generic_Dispatching_Constructor;
package body Messages is

   pragma Warnings (Off, "types for unchecked conversion have different sizes*");
   function Hash is new Ada.Unchecked_Conversion (Ada.Tags.Tag, Ada.Containers.Hash_Type);
   function Hash is new Ada.Unchecked_Conversion (Messages.Key_Type, Ada.Containers.Hash_Type);
   pragma Warnings (On, "types for unchecked conversion have different sizes*");

   package Key_Maps is new Ada.Containers.Hashed_Maps (Key_Type        => Messages.Key_Type,
                                                       Element_Type    => Ada.Tags.Tag,
                                                       Hash            => Hash,
                                                       "="             => Ada.Tags."=",
                                                       Equivalent_Keys => "=");

   package Tag_Maps is new Ada.Containers.Hashed_Maps (Key_Type        => Ada.Tags.Tag,
                                                       Element_Type    => Messages.Key_Type,
                                                       Hash            => Hash,
                                                       Equivalent_Keys => Ada.Tags."=");
   Key_Map : Key_Maps.Map;
   Tag_Map : Tag_Maps.Map;

   procedure Register (Key : Messages.Key_Type; Tag : Ada.Tags.Tag) is
   begin
      Key_Map.Insert (Key => Key, New_Item => Tag);
      Tag_Map.Insert (Key => Tag, New_Item => Key);
   end;

   function Input (S : not null access Ada.Streams.Root_Stream_Type'Class) return Root_Message'Class is
      Key : Key_Type;

      function Dispatching_Constructor is new Ada.Tags.Generic_Dispatching_Constructor
        (T           => Root_Message,
         Parameters  => Ada.Streams.Root_Stream_Type'Class,
         Constructor => Constructor);
   begin
      Key := Key_Type'Input (S);
      if Key_Map.Contains (Key) then
         return Ret : constant Root_Message'Class := Dispatching_Constructor (Key_Map (Key), S) do
            null;
         end return;
      else
         raise Constraint_Error with Key'Img & " not registerd.";
      end if;
   end;

   procedure Output (S : not null access Ada.Streams.Root_Stream_Type'Class; Item : Root_Message'Class) is
   begin
      Key_Type'Write (S, Tag_Map (Item'Tag));
      Root_Message'Class'Write (S, Item);
   end;

   procedure Read (S : not null access Ada.Streams.Root_Stream_Type'Class; Item : out Position) is
   begin
      Ada.Streams.Stream_Element'Read (S, Ada.Streams.Stream_Element (Item.X));
      Ada.Streams.Stream_Element'Read (S, Ada.Streams.Stream_Element (Item.Y));
      Ada.Streams.Stream_Element'Read (S, Ada.Streams.Stream_Element (Item.Z));
   end;
   
   procedure Write (S : not null access Ada.Streams.Root_Stream_Type'Class; Item : in Position) is
   begin
      Ada.Streams.Stream_Element'Write (S, Ada.Streams.Stream_Element (Item.X));
      Ada.Streams.Stream_Element'Write (S, Ada.Streams.Stream_Element (Item.Y));
      Ada.Streams.Stream_Element'Write (S, Ada.Streams.Stream_Element (Item.Z));
   end;

end Messages;
