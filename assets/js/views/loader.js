import MainView    from './main';
import PublicPlayerView from './public/player';

const views = {
  PublicPlayerView
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}
