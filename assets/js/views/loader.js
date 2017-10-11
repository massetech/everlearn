import MainView    from './main';
import PageIndexView from './page/index';
import MembershipTestView from './page/test';

// Collection of specific view modules
const views = {
  PageIndexView,
  MembershipTestView
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}
