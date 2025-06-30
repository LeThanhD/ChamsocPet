<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class RoleMiddleware
{
    public function handle(Request $request, Closure $next, ...$roles)
    {
        $user = Auth::user();

        // Chưa đăng nhập
        if (!$user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        // Kiểm tra vai trò hợp lệ
        if (!in_array(strtolower($user->Role), array_map('strtolower', $roles))) {
            return response()->json(['message' => 'Bạn không có quyền!'], 403);
        }

        return $next($request);
    }
}
