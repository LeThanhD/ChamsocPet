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
        return $this->hasMany(InvoiceMedicine::class, 'InvoiceID', 'InvoiceID');
    }


}

