<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\Medications;
use App\Models\Payment;
use App\Models\Service;
use App\Models\Appointment;

class Invoices extends Model
{
    protected $table = 'Invoices';
    protected $primaryKey = 'InvoiceID';
    public $incrementing = false;
    public $timestamps = false;

    protected $fillable = [
        'InvoiceID',
        'PetID',
        'CreatedAt',
        'TotalAmount',
        'AppointmentID',
        'ServicePrice',
        'MedicineTotal',
        'Status',      // ✅ Trạng thái hóa đơn (Chưa thanh toán, Đã thanh toán, v.v.)
        'Note',        // ✅ Dòng mô tả khuyến mãi như "Khuyến mãi 10%..."
    ];

    /**
     * Quan hệ với bảng Appointment
     */
    public function appointment()
    {
        return $this->belongsTo(Appointment::class, 'AppointmentID', 'AppointmentID');
    }

    /**
     * Quan hệ nhiều-nhiều với bảng Service qua bảng trung gian invoice_service
     */
    public function services()
    {
        return $this->belongsToMany(
            Service::class,
            'invoice_service',
            'InvoiceID',
            'ServiceID'
        );
    }

    /**
     * Quan hệ nhiều-nhiều với bảng Medications qua bảng trung gian invoice_medicines
     */
    public function medications()
    {
        return $this->belongsToMany(
            Medications::class,
            'invoice_medicines',
            'InvoiceID',
            'MedicineID'
        )->withPivot('Quantity');
    }

    /**
     * Quan hệ 1-nhiều với bảng Payment (nếu có bảng Payment để check trạng thái thanh toán)
     */
    public function payments()
    {
        return $this->hasMany(Payment::class, 'InvoiceID', 'InvoiceID');
    }
}
