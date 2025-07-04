<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

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
    ];

    public function appointment()
    {
        return $this->belongsTo(Appointment::class, 'AppointmentID', 'AppointmentID');
    }

   public function medicines()
{
    return $this->belongsToMany(
        Medications::class,      // Model bên kia
        'invoice_medicines',     // Tên bảng trung gian
        'InvoiceID',             // Khóa ngoại trên bảng trung gian trỏ đến bảng hiện tại
        'MedicineID'             // Khóa ngoại trên bảng trung gian trỏ đến bảng kia
    )->withPivot('Quantity');
}
   
}
