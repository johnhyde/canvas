import React, { Component } from 'react';
import { Route, Link } from 'react-router-dom';

import * as d3 from "d3";
import { parseSVG, simpleParseSVG } from "./lib/compile-svg";
import { initMapCanvas, drawMapCanvas, width, height } from "./lib/map-canvas";
import { createColorPicker } from "./lib/color";
import { ShareImage } from "./lib/share-image";
import { SaveImage } from "./lib/save-image";

import { store } from '/store';


export class MapCanvas extends Component {
  constructor(props) {
    super(props);
    this.state = {
      name: ''
    }
    this.onClickSave = this.onClickSave.bind(this);
  }

  componentDidMount() {
    const { props, state, animationRef } = this;
    const maps = props.metadata.type.split("-");
    if (maps.length > 1) {
      const json = store.state.maps[maps[1]];
      initMapCanvas(json, props.metadata);
      drawMapCanvas(json, props, path);
      createColorPicker(width);
      }
  }

  onClickSave (removeColor) {
    const type = this.props.metadata.type.split("-");
    const canvas = d3.select("#canvas").node().cloneNode(true);
    if (removeColor) {
      d3.select(canvas).select(".legend").selectAll("*").remove();
    }
    const svgString = simpleParseSVG(d3.select(canvas).node(), 'map');
    const chunkSize = 700 * 2**9;
    let last = false;
    let i = 0;
    let chunks = [];
    while (i < svgString.length) {
      this.props.api.image.save(
        this.props.metadata.location,
        this.props.name,
        svgString.slice(i, chunkSize + i),
        ((i + chunkSize ) >= svgString.length),
        'svg');
      i += chunkSize;
    }
  }

  render() {
    const { props, state, animationRef } = this;
    d3.select(".foreground").selectAll("path").remove();
    d3.select(".background").selectAll("path").remove();
    if (props.metadata) {
      const maps = props.metadata.type.split("-");
      const json = store.state.maps[maps[1]];
      initMapCanvas(json, props.metadata);
      drawMapCanvas(json, props);
    }

    return (
      <div className="h-100 w-100 pa3 pt4 bg-gray0-d white-d flex flex-column">
        <div className="w-100 dn-m dn-l dn-xl inter pt1 pb6 f8">
          <Link to="/~canvas/">{"⟵ Canvas"}</Link>
        </div>
        <div className="absolute mw5"
             style={{right: "20px", top: "20px"}}
          >
          <ShareImage chats={props.chats} name={props.name} type={'svg'}
                      saved={props.metadata.saved} api={props.api}/>
          <SaveImage save={this.onClickSave} hasMesh={false} saved={props.metadata.saved} />
        </div>
        <div ref="canvas" className="w-100 mb4 pr6 pr0-l pr0-xl">
          <svg className="db" id="canvas" width={ width } height={ height }>
            <g transform="translate(25,25)" className="foreground" style={{ cursor: "pointer", strokeOpacity: .5 }}/>
            <g transform="translate(25,25)" className="background" />
            <g className="legend" />
          </svg>
        </div>
      </div>
    )
  }
}
