import React, {useEffect, useState, useContext, createContext, useCallback, useMemo} from 'react';
import axios from "axios";
import Cookies from "js-cookie";
import { googleLogout } from "@react-oauth/google";
import { useGoogleLogin } from "@react-oauth/google";
import { useLocalStorage } from "./useLocalStorage";

type TUser = {
  id?: string;
  email?: string;
  verified_email?: boolean;
  name?: string;
  given_name?: string;
  family_name?: string;
  picture?: string;
  hd?: string;
};

type TToken = {
  accessToken: string;
  expiresOn: number;
}

type TAuthContext = {
  token?: TToken;
  user?: TUser;
  login?: () => void;
  logout?: () => void;
}

const AuthContext = createContext<TAuthContext>({} as TAuthContext);
const useAuth = () => useContext(AuthContext);

const AuthProvider = ({ children }: { children: React.ReactElement }) => {
  const [user, setUser] = useState<TUser | undefined>(undefined);
  const [token, setToken, removeToken] = useLocalStorage('token');

  const login = useGoogleLogin({
    onSuccess: (codeResponse) => onSuccess(codeResponse),
    onError: (error) => console.log('Login Failed: ', error)
  });

  const onSuccess = async (codeResponse: any) => {
    const expiresOn = (codeResponse.expires_in * 1000) + Date.now();
    Cookies.set('token', codeResponse.access_token, { expires: new Date(expiresOn), secure: true });
    setToken({ expiresOn, accessToken: codeResponse.access_token });
    console.log("Successfully logged in!");
  }

  const logout = useCallback(() => {
    setUser(undefined);
    removeToken();
    googleLogout();
  }, [removeToken]);

  const isTokenExpired = !token || !token.expiresOn || token.expiresOn <= Date.now()

  useEffect(() => {
    if (!user && isTokenExpired) {
      logout();
    } else {
      const timer = setTimeout(() => {
        if (isTokenExpired) {
          logout();
        }
      }, 1000);
      return () => clearTimeout(timer);
    }
  }, [isTokenExpired, logout, user]);

  useEffect(() => {
    if (token?.accessToken)
      fetchUserProfile(token.accessToken)
        .then(data => setUser(data));
  }, [token])

  const fetchUserProfile = async (token: string) => {
    try {
      const res = await axios.get(`https://www.googleapis.com/oauth2/v1/userinfo?access_token=${token}`, {
        headers: {
          Authorization: `Bearer ${token}`,
          Accept: 'application/json'
        }
      });
      return await res.data
    } catch (err) {
      console.log(err);
    }
  }

  const value = useMemo(
    () => ({
      user,
      token,
      login,
      logout,
    }),
    [user, token, login, logout],
  );

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  )
}

export { useAuth, AuthProvider }