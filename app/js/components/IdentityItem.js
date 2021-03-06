import React, { Component, PropTypes } from 'react'
import { Link } from 'react-router'

import Image from './Image'

class IdentityItem extends Component {
  static propTypes = {
    label: PropTypes.string.isRequired,
    avatarUrl: PropTypes.string.isRequired,
    url: PropTypes.string.isRequired,
    pending: PropTypes.bool.isRequired
  }

  constructor(props) {
    super(props)
    this.state = {}
  }

  render() {
    return (
      <li className="col-md-6 col-lg-4 col-xl-3 card-list-wrap">
        <Link to={this.props.url} className="card profile-list-card container-fluid m-b-35">
          <div className="card-avatar profile-list-avatar">
            <Image src={this.props.avatarUrl}
              fallbackSrc="/images/avatar.png" className="img-circle" />
          </div>
          <div>
            <ul className="profile-card-list">
              <li>
                <h3 className="card-title profile-list-card-title">
                  {this.props.label}
                </h3>
              </li>
              <li>
                {this.props.pending ?
                <p className="card-subtitle profile-list-card-subtitle">
                 (pending)
                </p>
                : <p></p> }
              </li>
            </ul>
          </div>            
        </Link>
      </li>
    )
  }
}

export default IdentityItem