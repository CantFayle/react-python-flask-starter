import React, {useEffect, useState} from 'react';
import {formatDate} from "../utils";
import {buttonStyle} from "../styles";
import {useAuth} from "../hooks";

function HomePage() {
  const { user, token, logout } = useAuth();
  const [currentTime, setCurrentTime] = useState<Date>(new Date());

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentTime(new Date());
    }, 1000);
    return () => clearInterval(interval);
  }, []);

  const data = {
    'Name': user?.name,
    'Email': user?.email,
    'Token expires at': formatDate(new Date(token?.expiresOn || '')),
    'Current time': formatDate(currentTime)
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem', alignItems: 'center' }}>
      <button
        onClick={logout}
        style={buttonStyle}
      >
        <span>Sign out</span>
      </button>
      <table>
        <tbody>
        {Object.entries(data).map(([key, value]) =>
          <tr>
            <td style={{textAlign: 'right'}}>{key}:</td>
            <td style={{textAlign: 'left', paddingLeft: '1rem'}}>{value}</td>
          </tr>
        )}
        </tbody>
      </table>
    </div>
  );
}

export default HomePage;