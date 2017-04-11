
'use strict';
import React, { Component } from 'react';

import {
    NativeMethodsMixin,
    NativeModules,
    StyleSheet,
    View,
    requireNativeComponent,
} from 'react-native';

var SCROLLPAGEVIEW = 'ScrollPageView';

function extend(el, map) {
    for (var i in map)
        if (typeof(map[i])!='object')
            el[i] = map[i];
    return el;
}

var ScrollPageView = React.createClass({
   mixins: [NativeMethodsMixin],

   propTypes: {
      onPageViewDidAppearedAtIndex: React.PropTypes.func,
   },

   getInitialState: function() {
      return this._stateFromProps(this.props);
   },

   componentWillReceiveProps: function(nextProps) {
      var state = this._stateFromProps(nextProps);
      this.setState(state);
   },

   _stateFromProps: function(props) {
      var pages = [];
      React.Children.forEach(props.children, function (page, index) {
         var el = {};
         extend(el, page.props);
         pages.push(el);
      });

      this.pages = pages;
      return {pages};
   },

   render: function() {
      return (
         <View style={[{flex: 1}, this.props.style]}>
            <RNScrollPageView
               ref={SCROLLPAGEVIEW}
               style={this.props.style}
               pages={this.state.pages}
               curIndex={this.props.curIndex}
               onPageViewDidAppearedAtIndex={this._onPageViewDidAppearedAtIndex}>
            </RNScrollPageView>
         </View>
      );
   },
   
  setPageIndex: function(index) {
        NativeModules.RNScrollPageViewManager.setPageIndex(
        findNodeHandle(this.tableView),
        index
      );
   },

   _onPageViewDidAppearedAtIndex: function(event) {
      var data = event.nativeEvent;
      this.props.onPageViewDidAppearedAtIndex(data.index);
   }

});

ScrollPageView.Page = React.createClass({
   propTypes: {
      label: React.PropTypes.string,
      renderCell: React.PropTypes.string,
      pageIndex: React.PropTypes.number,
   },

   render() {
      return null;
   }
});

var RNScrollPageView = requireNativeComponent('RNScrollPageView', null);

module.exports = ScrollPageView;
