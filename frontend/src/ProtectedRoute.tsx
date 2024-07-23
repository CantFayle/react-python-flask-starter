import React from 'react';
import { Navigate, Outlet, useLocation } from 'react-router-dom';
import {useAuth} from "./hooks";

const ProtectedRoute = (
  {
    redirectPath = '/login',
    children
  }: {
    redirectPath?: string,
    children?: React.ReactElement
  }
): React.ReactElement => {
  const prevLocation = useLocation();
  const { token} = useAuth();
  if (!token) {
    return (
      <Navigate
        to={redirectPath}
        replace
        state={{ redirectTo: prevLocation }}
      />
    );
  }

  return children ? children : <Outlet />;
};

export default ProtectedRoute;