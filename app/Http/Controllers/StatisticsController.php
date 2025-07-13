<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class StatisticsController extends Controller
{
    public function getStats(Request $request)
    {
        $from = $request->query('from');
        $to = $request->query('to');

        if (!$from || !$to) {
            return response()->json([
                'status' => 'error',
                'message' => 'Vui lòng cung cấp tham số from và to (yyyy-mm-dd)'
            ], 400);
        }

        // 1. Tổng số lượt đăng ký khám
        $totalAppointments = DB::table('appointments')
            ->whereBetween('AppointmentDate', [$from, $to])
            ->count();

        // 2. Tổng số thú cưng duy nhất đến khám
        $totalPets = DB::table('appointments')
            ->whereBetween('AppointmentDate', [$from, $to])
            ->distinct('PetID')
            ->count('PetID');

        // 2b. Thú cưng theo loài (giả định bảng pets có PetID, Species)
        $petsBySpecies = DB::table('appointments')
            ->join('pets', 'appointments.PetID', '=', 'pets.PetID')
            ->whereBetween('appointments.AppointmentDate', [$from, $to])
            ->select('pets.Species', DB::raw('count(*) as count'))
            ->groupBy('pets.Species')
            ->get();

        // 3. Thống kê dịch vụ theo ServiceName
        $servicesStats = DB::table('appointment_service')
            ->join('appointments', 'appointment_service.appointment_id', '=', 'appointments.AppointmentID')
            ->join('services', 'appointment_service.service_id', '=', 'services.ServiceID')
            ->whereBetween('appointments.AppointmentDate', [$from, $to])
            ->select('services.ServiceName', DB::raw('count(*) as count'))
            ->groupBy('services.ServiceName')
            ->get();

        $totalServices = $servicesStats->sum('count');

        foreach ($servicesStats as $stat) {
            $stat->percentage = $totalServices > 0 ? round(($stat->count / $totalServices) * 100, 2) : 0;
        }

        return response()->json([
            'totalAppointments' => $totalAppointments,
            'totalPets' => $totalPets,
            'petsBySpecies' => $petsBySpecies,
            'servicesPercentage' => $servicesStats
        ]);
    }
}
