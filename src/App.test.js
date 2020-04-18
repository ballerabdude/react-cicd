import React from 'react';
import Enzyme, { shallow, mount, render } from 'enzyme';
import Adapter from "enzyme-adapter-react-16";
import App from './App';

Enzyme.configure({ adapter: new Adapter() });

describe("App component", () => {
  // Test to see if componet loads
  test("renders", () => {
    const wrapper = shallow(<App />);

    expect(wrapper.exists()).toBe(true);
  });

  // While the page is loading we need to show the loading test
  test("Loading text and header is only shown", () => {
    const wrapper = shallow(<App />);
    expect(wrapper.find("p").text()).toEqual("Loading...");
    expect(wrapper.html()).toEqual('<h2>Random Post</h2><div><p>Loading...</p></div>')
  });

  // While the page has loaded the data loading text is removed
  test("Loading text disappears when data received", () => {
    const wrapper = shallow(<App />);
    wrapper.setState({
      isLoading: false,
      posts: [{_id: 123, title: 123, content: 123}]
    });
    
    if (wrapper.find("p").exists()) {
      expect(wrapper.find("p").text()).not.toEqual("Loading...");
    }
    
  });

  // Only header is shown when no data or failed http request
  test("Only header is shown when no data available", () => {
    const wrapper = shallow(<App />);
    wrapper.setState({
      isLoading: false,
      posts: []
    });
    
    // We should not have any p tags 
    expect(wrapper.find("p")).toEqual({})
    expect(wrapper.html()).toEqual('<h2>Random Post</h2><div></div>')
  });

});