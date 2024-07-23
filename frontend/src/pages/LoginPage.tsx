import React from 'react';
import {buttonStyle} from "../styles";
import {useAuth} from "../hooks";

const GoogleLogo = () =>
  <img
    src="https://img.icons8.com/color/48/000000/google-logo.png"
    alt="Google Logo"
    width={24}
    height={24}
    style={{
      marginRight: '8px',
      backgroundColor: 'white',
      borderRadius: '50%',
      padding: '3px'
    }}
  />

function LoginPage() {
  const { login } = useAuth();
  return (
    <div>
      <button
        onClick={login}
        style={buttonStyle}
      >
        <GoogleLogo />
        <span>Sign in with Google</span>
      </button>
    </div>
  );
}

export default LoginPage;