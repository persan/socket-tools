--  begin read only
--  This file is auto generated.
package body Messages.Dispatchers is
   use Ada.Tags;

   procedure Dispatch (App : in out Application_Interface'Class; Data : Messages.Root_Message'Class) is
   begin
      if Data'Tag = Messages.One_Messages.One_Message'Tag then
         App.On_One_Message (Messages.One_Messages.One_Message (Data));
      elsif Data'Tag = Messages.Two_Messages.Two_Message'Tag then
         App.On_Two_Message (Messages.Two_Messages.Two_Message (Data));
      end if;
   end;

end Messages.Dispatchers;
--  end read only
