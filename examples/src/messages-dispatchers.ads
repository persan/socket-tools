--  begin read only
--  This file is auto generated.
with Messages.One_Messages;
with Messages.Two_Messages;

package Messages.Dispatchers is
   type Application_Interface is limited interface;

   procedure On_One_Message (App : in out Application_Interface; Msg : Messages.One_Messages.One_Message) is null;

   procedure On_Two_Message (App : in out Application_Interface; Msg : Messages.Two_Messages.Two_Message) is null;

   procedure Dispatch (App : in out Application_Interface'Class; Data : Messages.Root_Message'Class);

end Messages.Dispatchers;
--  end read only
