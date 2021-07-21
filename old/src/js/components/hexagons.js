import React, { Component } from 'react';
import { Route, Link } from 'react-router-dom';

import * as d3 from "d3";
import { parseSVG, simpleParseSVG } from "./lib/compile-svg";
import { initHexMesh,
         drawHexCanvas,
         width,
         height,
         radius }
from "./lib/hex-canvas";
import { ShareImage } from "./lib/share-image";
import { SaveImage } from "./lib/save-image";
import { createColorPicker } from "./lib/color";


export class Hexagons extends Component {
  constructor(props) {
    super(props);
    this.state = {
      name: '',
      data: {}
    }
    this.onClickSave = this.onClickSave.bind(this);
  }

  componentDidMount() {
    drawHexCanvas(this.props);
    initHexMesh();
    createColorPicker(width);
  }

  onClickSave (removeColor, removeMesh) {
    const canvas = d3.select("#canvas").node().cloneNode(true);
    if (removeColor) {
      d3.select(canvas).select(".legend").selectAll("*").remove();
    }
    if (removeMesh) {
      d3.select(canvas).select(".mesh-group").selectAll("*").remove();
    }
    const svgString = simpleParseSVG(d3.select(canvas).node(), 'mesh');
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
    const { props, state } = this;
    d3.select(".hexagon").selectAll("path").remove();
    if (this.props.canvas) {
      drawHexCanvas(this.props);
    }
    return (
      <div className="h-100 w-100 bg-gray0-d white-d flex flex-column">
        <div className="w-100 dn-m dn-l dn-xl inter pt1 pb6 f8">
          <Link to="/~canvas/">{"⟵ Canvas"}</Link>
        </div>
        { (props.metadata.type !== 'mesh-welcome') ?
          <div className="absolute mw5"
               style={{right: "20px", top: "20px"}}
            >
            <ShareImage chats={props.chats} name={props.name} type={'svg'}
                        saved={props.metadata.saved} api={props.api}/>
            <SaveImage save={this.onClickSave} hasMesh={true} saved={props.metadata.saved} />
          </div> : null
        }
        <div ref="canvas" className="w-100 pr0-l pr0-xl" style={{overflow: "hidden"}}>
          <svg className="db" id="canvas" width={width} height={height}
               viewBox={`0 0 ${width} ${height}`}
               perserveaspectratio="xMinYMid">
            <g className="hexagon" />
            <g className="mesh-group" />
            <g className="legend" />
          </svg>
        </div>
      </div>
    )
  }
}
