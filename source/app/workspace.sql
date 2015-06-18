--  VERSION @SV_VERSION@
--
--    NAME
--      _install_workspace.sql
--
--    DESCRIPTION
--      Intended to install the Workspace and default ADMIN user
--
--    NOTES
--      Assumes the SYS user is connected.
--
--    Arguments:
--      ^1 = Password for ADMIN user
--      ^parse_as_user = Schema assigned
--
--    MODIFIED   (MM/DD/YYYY)
--      tsthilaire   16-FEB-2014  - Created   
--
--

-- terminate script when an error occurs
WHENEVER SQLERROR EXIT SQL.SQLCODE
--  feedback - Displays the number of records returned by a script ON=1
set feedback off
--  termout - display of output generated by commands in a script that is executed
set termout on
-- serverout - allow dbms_output.put_line
set serverout on
--  define - Sets the character used to prefix substitution variables
set define '^'
--  concat - Sets the character used to terminate a substitution variable ON=.
set concat on
--  verify off prevents the old/new substitution message
set verify off

PROMPT  =============================================================================
PROMPT  ==   W O R K S P A C E 
PROMPT  =============================================================================
PROMPT

def myscript_pw ='^1'
def myscript_parse_as_user = '^2'
def myscript_admin_email = '^3'

DECLARE
  l_workspace   varchar2(20)  := 'SERT';
  l_workspace_id  number;
BEGIN

  -- Run the creation steps
  dbms_output.put_line('== Creating Workspace: '|| l_workspace);

  -- Set the APEX session
  wwv_flow_api.set_security_group_id(10);

  -- Create the workspace
  APEX_INSTANCE_ADMIN.ADD_WORKSPACE(
      p_workspace           => l_workspace,
      p_primary_schema      => '^myscript_parse_as_user',
      p_additional_schemas  => NULL
      );
  
  -- remove line to not enable the workspace
  apex_instance_admin.enable_workspace(l_workspace);     
  
  -- Save the new workspace
  COMMIT;

  dbms_output.put_line('== Workspace Created');

  -- get the new ID so we can use the security grup
  select workspace_id
    into l_workspace_id
    from apex_workspaces
    where workspace = l_workspace;
  
  -- set the security group to add user to
  apex_util.set_security_group_id(p_security_group_id => l_workspace_id);

  -- add default user..
  APEX_UTIL.CREATE_USER(
          p_user_name                     => 'ADMIN'
         ,p_web_password                  => '^myscript_pw'
         ,p_email_address                 => '^myscript_admin_email'
         ,p_developer_privs               => NULL
         ,p_default_schema                => '^myscript_parse_as_user'
         ,p_allow_access_to_schemas       => '^myscript_parse_as_user'
         ,p_change_password_on_first_use  => 'N');

  -- be sure to save changes
  COMMIT;

  dbms_output.put_line('== ADMIN User Created');

END;
/




