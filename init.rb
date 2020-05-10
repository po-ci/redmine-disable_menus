Redmine::Plugin.register :disable_menus do

  name 'Disable Activity'
  author 'Cristian Incarnato'
  version '1.0.0'
  description 'Disable overview and activity tab & mail change behavior'

  Redmine::MenuManager.map(:project_menu).delete(:activity)
  Redmine::MenuManager.map(:project_menu).delete(:overview)
end
