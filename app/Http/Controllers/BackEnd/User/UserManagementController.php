<?php

namespace App\Http\Controllers\BackEnd\User;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Response;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Validator;

class UserManagementController extends Controller
{
    public function index(Request $request)
    {
        $searchKey = null;

        if ($request->filled('info')) {
            $searchKey = $request->input('info');
        }

        $users = User::when($searchKey, function ($query, $searchKey) {
            return $query->where('username', 'like', '%' . $searchKey . '%')
                ->orWhere('email', 'like', '%' . $searchKey . '%');
        })
            ->orderBy('id', 'desc')
            ->paginate(10);

        return view('backend.end-user.user.index', compact('users'));
    }

    public function show($id)
    {
        $userInfo = User::findOrFail($id);

        return view('backend.end-user.user.details', compact('userInfo'));
    }

    public function changePassword($id)
    {
        $userInfo = User::findOrFail($id);

        return view('backend.end-user.user.change-password', compact('userInfo'));
    }

    public function updatePassword(Request $request, $id)
    {
        $rules = [
            'new_password' => 'required|confirmed',
            'new_password_confirmation' => 'required',
        ];

        $messages = [
            'new_password.confirmed' => 'Password confirmation does not match.',
            'new_password_confirmation.required' => 'The confirm new password field is required.',
        ];

        $validator = Validator::make($request->all(), $rules, $messages);

        if ($validator->fails()) {
            return Response::json([
                'errors' => $validator->getMessageBag()->toArray(),
            ], 400);
        }

        $user = User::findOrFail($id);

        $user->update([
            'password' => Hash::make($request->new_password),
        ]);

        Session::flash('success', 'Updated Successfully');

        return Response::json(['status' => 'success'], 200);
    }

    public function updateEmailStatus(Request $request, $id)
    {
        $user = User::findOrFail($id);

        if ($request->email_status === 'verified') {
            $user->update(['email_verified_at' => now()]);
        } else {
            $user->update(['email_verified_at' => null]);
        }

        Session::flash('success', 'Updated Successfully');

        return redirect()->back();
    }

    public function updateAccountStatus(Request $request, $id)
    {
        $user = User::findOrFail($id);

        $user->update(['status' => $request->account_status]);

        Session::flash('success', 'Updated Successfully');

        return redirect()->back();
    }

    public function destroy($id)
    {
        $user = User::findOrFail($id);
        $user->delete();

        Session::flash('success', 'Deleted Successfully');

        return redirect()->back();
    }

    public function bulkDestroy(Request $request)
    {
        $ids = $request->ids;

        if (is_array($ids)) {
            User::whereIn('id', $ids)->delete();
        }

        Session::flash('success', 'Deleted Successfully');

        return Response::json(['status' => 'success'], 200);
    }
}
